import React from 'react'
import { Link } from 'react-router-dom'
import { Box, Text, Flex, Divider, VStack, Heading } from '@chakra-ui/react'

import { ArrowIcon } from '@ui/components'
import { Routes, createRoute } from '@ui/Routes'
// import { formatUnixTs, formatFinishDate } from '@ui/utils'
import { SubscriptionInstance } from '@ui/models'
import { convertUnixTimeToDuration } from '@ui/utils'

export const Card = (subscription: SubscriptionInstance) => {
  return (
    <Flex
      data-testid="subscription-card"
      sx={{
        transform:
          'translate3d(0px, 0px, 0px) scale3d(1, 1, 1) rotateX(0deg) rotateY(0deg) rotateZ(0deg) skew(0deg)',
        transformStyle: 'preserve-3d',
        transition: 'all 250ms ease-in-out',
        ':hover': {
          transform:
            'translate3d(0px, -8px, 0px) scale3d(1, 1, 1) rotateX(0deg) rotateY(0deg) rotateZ(0deg) skew(0deg)',
          transformStyle: 'preserve-3d'
        },
        '.arrow': {
          transform:
            'translate3d(0px, 0px, 0px) scale3d(1, 1, 1) rotateX(0deg) rotateY(0deg) rotateZ(0deg) skew(0deg)',
          transformStyle: 'preserve-3d',
          transition: 'all 250ms ease-in-out'
        },
        '&:hover': {
          '.arrow': {
            transform:
              'translate3d(8px, 0px, 0px) scale3d(1, 1, 1) rotateX(0deg) rotateY(0deg) rotateZ(0deg) skew(0deg)',
            transformStyle: 'preserve-3d'
          }
        }
      }}
      direction="column"
      key={subscription.tokenId}
      border="1px"
      borderColor="brand.gray_10"
      _hover={{
        borderColor: 'brand.primary'
      }}
      padding="6"
      bg="white"
      boxShadow="brand.base"
      borderRadius="base"
      as={Link}
      to={createRoute({
        route: Routes.SubscriptionDetail,
        id: subscription.tokenId
      })}>
      <VStack spacing="6" mb="6" alignItems="start">
        <Heading
          size="md"
          fontWeight="700"
          mb="6"
          color="brand.primary"
          wordBreak="break-all">
          {subscription.domain}
        </Heading>
        <Divider orientation="horizontal" />

        <Flex justify="space-between" w="100%">
          <Text fontSize={'sm'}>Renewal duration:</Text>
          <Text fontSize={'sm'}>
            {convertUnixTimeToDuration(subscription.renewalDuration.toString())}
          </Text>
        </Flex>

        <Flex justify="space-between" w="100%">
          <Text fontSize={'sm'}>Available renewals:</Text>
          <Text fontSize={'sm'}>
            {subscription.renewalCount - subscription.renewedCount}
          </Text>
        </Flex>
      </VStack>
      <Box w="100%" mt="auto">
        <Divider orientation="horizontal" mb="6" />
        <Flex justify="end" w="100%">
          <ArrowIcon className="arrow" />
        </Flex>
      </Box>
    </Flex>
  )
}
